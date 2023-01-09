<?php
/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

use Carbon\Carbon;
use CharlotteDunois\Collect\Collection;

class User implements JsonSerializable
{
    public ?string $locale;
    public bool $isLogged;

    public bool $isBanned;
    public bool $isModerator;
    public bool $isMember;

    public string $id;
    public ?string $login;
    public string $displayName;

    public ?int $idHat;
    public ?string $hatConfig;

    public ?string $apiKey;

    public Carbon $created;
    public Carbon $updated;

    public function __construct(protected TRSite $trs)
    {
    }

    public static function createFromSession(TRSite $trs): self
    {
        if (!array_key_exists("trLogged", $_SESSION ?? [])) {
            $_SESSION['trLogged'] = false;
            return self::createGuest($trs);
        }
        if (array_key_exists("trUser", $_SESSION ?? [])) {
            // we have a user context! let's grab deets :)
            try {
                $user = self::createFromID($trs, $_SESSION['trUser'], true);
                $user->isLogged = true;
                return $user;
            } catch (\Throwable $e) {
                $trs->log("user_possible_sessionbug", $user->id ?? null, remarks: json_encode($_SESSION));
                unset($_SESSION['trLogged']);
                unset($_SESSION['trUser']);
                die("Unable to authenticate! Try again, if that doesnt work clear your cookies.");
            }
        } else {
            unset($_SESSION['trUser']);
            $_SESSION['trLogged'] = false;
            return self::createGuest($trs);
        }
    }

    private static function createGuest(TRSite $trs): self
    {
        $user = new static($trs);
        $user->isLogged = false;
        $user->displayName = "Guest";
        $user->locale = "en";

        return $user;
    }

    public static function createFromID(TRSite $trs, string $idUser, bool $breakCache = false): self
    {
        static $cache = [];
        if (array_key_exists($idUser, $cache) && !$breakCache) {
            return self::createFromDBRow($trs, $cache[$idUser]);
        }
        $qb = $trs->db->createQueryBuilder();
        $qb->select("*")
            ->from("users")
            ->where('idUser = ?')
            ->setParameter(0, $idUser);
        $res = $qb->fetchAssociative();
        if (!$res) {
            throw new \InvalidArgumentException();
        }
        $cache[$idUser] = $res;

        return self::createFromDBRow($trs, $res);
    }

    private static function createFromDBRow(TRSite $trs, array $res): self
    {
        $user = new static($trs);

        $user->id = $res['idUser'];
        $user->login = $res['login'];
        $user->isMember = $res['isMember'];
        $user->isBanned = $res['isBanned'];
        $user->isModerator = $res['isModerator'];
        $user->displayName = $res['displayName'];
        $user->locale = $res['locale'];
        $user->apiKey = $res['apiKey'];
        $user->hatConfig = $res['hatConfig'];
        $user->created = new Carbon($res["created"]);
        $user->updated = new Carbon($res["updated"]);
        if (!is_null($res['hat'])) {
            $user->idHat = $res['hat'];
        } else {
            $user->idHat = null;
        }
        return $user;
    }

    public static function createFromBulkID(TRSite $trs, array $users): Collection
    {
        $qb = $trs->db->createQueryBuilder();
        $qb->select("*")->from("users")->where("idUser IN (?)")
            ->setParameter(0, $users, \Doctrine\DBAL\Connection::PARAM_STR_ARRAY);

        $collect = new Collection();
        foreach ($qb->fetchAllAssociative() as $row) {
            $collect->set($row['idUser'], self::createFromDBRow($trs, $row));
        }

        return $collect;
    }

    public static function tryFetchUserFromLogin(TRSite $trs, string $login, bool $breakCache = false): ?self
    {
        static $cache = [];
        if (array_key_exists($login, $cache) && !$breakCache) {
            return self::createFromDBRow($trs, $cache[$login]);
        }
        $qb = $trs->db->createQueryBuilder();
        $qb->select("*")
            ->from("users")
            ->where('login = ?')
            ->setParameter(0, $login);
        $res = $qb->fetchAssociative();
        if (!$res) {
            return null;
        }
        $cache[$login] = $res;

        return self::createFromDBRow($trs, $res);
    }

    public static function createFromAPIKey(TRSite $trs, string $key): self
    {
        $qb = $trs->db->createQueryBuilder();
        $qb->select("*")
            ->from("users")
            ->where('apiKey = ?')
            ->setParameter(0, $key);
        $res = $qb->fetchAssociative();
        if (!$res) {
            throw new \InvalidArgumentException();
        }

        return self::createFromDBRow($trs, $res);
    }

    public static function createNewUser(TRSite $trs, string $id, string $displayName): self
    {
        $qb = $trs->db->createQueryBuilder()->insert("users")->values(
            ['idUser' => '?', 'displayName' => '?']
        )
            ->setParameter(0, $id, 'text')
            ->setParameter(1, $displayName, 'text');
        $qb->executeStatement();
        $trs->log("user_create", remarks: $id);


        $user = self::createFromID($trs, $id);
        $user->refreshApiKey();
        return $user;
    }

    public function refreshApiKey(): string
    {
        $key = self::generateApiKey();
        $this->trs->log("user_regenAPI", user: $this);
        $this->apiKey = $key;
        $this->update();
        return $key;
    }

    public static function generateApiKey(): string
    {
        return mb_strtolower(str_pad(bin2hex(random_bytes(32)), 64, "0", STR_PAD_LEFT));
    }

    public function update(): bool
    {
        return $this->trs->db->executeStatement(
            "update users set isMember = ?, isBanned = ?, isModerator = ?, displayName = ?, locale = ?, apiKey = ?, login = ?, hat = ?, hatConfig = ? where idUser = ?",
            [
                $this->isMember,
                $this->isBanned,
                $this->isModerator,
                $this->displayName,
                $this->locale,
                $this->apiKey,
                $this->login,
                $this->idHat ?? null,
                $this->hatConfig ?? null,
                $this->id
            ],
            [
                "boolean",
                "boolean",
                "boolean",
                "string",
                "string",
                "string",
                "string",
                "integer",
                "string",
                "string"
            ]
        );
    }

    public function logout()
    {
        $this->trs->user = self::createGuest($this->trs);
        session_destroy();
    }

    public function login()
    {
        $this->trs->user = $this;
        $_SESSION['trLogged'] = true;
        $_SESSION['trUser'] = $this->id;
    }

    public function getSessions(): Collection
    {
        $res = $this->trs->db->executeQuery(
            "select * from sessions where idUser = ?",
            [$this->id], ['string']
        );
        $x = new Collection();
        while ($row = $res->fetchAssociative()) {
            $v = [];
            $v['idSession'] = $row['idSession'];
            $v['ip'] = inet_ntop($row['ip']);
            $v['updated'] = new Carbon($row['updated']);
            $v['userAgent'] = $row['userAgent'];
            $x->set($row['idSession'], $v);
        }
        return $x;
    }

    public function jsonSerialize(): object
    {
        return (object)[
            'uid' => $this->id,
            'login' => $this->login,
            'displayName' => $this->displayName,
            'locale' => $this->locale,
            'hat' => $this->idHat ?? null,
            'hatConfig' => $this->hatConfig ?? null,
            'created' => $this->created->timestamp,
            'updated' => $this->updated->timestamp,
        ];
    }
}