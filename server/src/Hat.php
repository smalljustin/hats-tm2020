<?php
/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

use CharlotteDunois\Collect\Collection;

class Hat implements JsonSerializable
{
    public const MAX_HAT_SIZE = 1024 * 1024 * 8;
    public int $idHat;
    public string $name;
    public User $author;
    public bool $isApproved;
    public \Carbon\Carbon $created;
    public \Carbon\Carbon $updated;
    public string $data;

    public function __construct(protected TRSite $trs)
    {
    }

    public static function getHatsByUser(TRSite $trs, User $user): Collection
    {
        $qb = $trs->db->createQueryBuilder();
        $qb->select("*")
            ->from("hats")
            ->where('author = ?')
            ->setParameter(0, $user->id);

        $collect = new Collection();
        foreach ($qb->fetchAllAssociative() as $row) {
            $collect->set($row['idHat'], self::createFromDBRow($trs, $row));
        }

        return $collect;
    }

    public static function createFromDBRow(TRSite $trs, array $res): self
    {
        $hat = new static($trs);

        $hat->idHat = $res['idHat'];
        $hat->name = $res['name'];
        $hat->author = User::createFromID($trs, $res['author']);
        $hat->isApproved = $res['isApproved'];
        $hat->data = $res['data'];
        $hat->created = new \Carbon\Carbon($res['created']);
        $hat->updated = new \Carbon\Carbon($res['updated']);

        return $hat;
    }

    public static function createFromID(TRSite $trs, string $idHat, bool $breakCache = false): self
    {
        static $cache = [];
        if (array_key_exists($idHat, $cache) && !$breakCache) {
            return self::createFromDBRow($trs, $cache[$idHat]);
        }
        $qb = $trs->db->createQueryBuilder();
        $qb->select("*")
            ->from("hats")
            ->where('idHat = ?')
            ->setParameter(0, $idHat);
        $res = $qb->fetchAssociative();
        if (!$res) {
            throw new \InvalidArgumentException();
        }
        $cache[$idHat] = $res;

        return self::createFromDBRow($trs, $res);
    }

    public static function getAllHats(TRSite $trs): Collection
    {
        $qb = $trs->db->createQueryBuilder();
        $qb->select("*")->from("hats");

        $collect = new Collection();
        foreach ($qb->fetchAllAssociative() as $row) {
            $collect->set($row['idHat'], self::createFromDBRow($trs, $row));
        }

        return $collect;
    }

    public static function getPubAndUserHats(TRSite $trs, ?User $user = null)
    {
        $qb = $trs->db->createQueryBuilder();
        $qb->select("*")->from("hats")->where("isApproved = 1");

        if (!is_null($user)) {
            $qb->orWhere('author = ?')->setParameter(0, $user->id);
        }

        $collect = new Collection();
        foreach ($qb->fetchAllAssociative() as $row) {
            $collect->set($row['idHat'], self::createFromDBRow($trs, $row));
        }

        return $collect;
    }

    public function create()
    {
        $qb = $this->trs->db->createQueryBuilder()->insert("hats")->values([
            'idHat' => '?',
            'name' => '?',
            'author' => '?',
            'data' => '?',
            'isApproved' => '?'
        ])
            ->setParameter(0, $this->idHat, 'integer')
            ->setParameter(1, $this->name, 'text')
            ->setParameter(2, $this->author->id, 'text')
            ->setParameter(3, $this->data, 'text')
            ->setParameter(4, $this->isApproved, 'boolean');
        $qb->executeStatement();

        $this->trs->log("hat_create", $this->idHat, user: $this->author);
    }

    public function update(): bool
    {
        return $this->trs->db->executeStatement(
            "update hats set name = ?, author = ?, isApproved = ?, data = ? where idHat = ?",
            [
                $this->name,
                $this->author->id,
                $this->isApproved,
                $this->data,
                $this->idHat
            ],
            [
                "string",
                "string",
                "boolean",
                "string",
                "integer"
            ]
        );
    }

    public function getSizeString(): string
    {
        $len = strlen($this->data);

        $base = log(strlen($this->data), 1024);
        $suffixes = array('bytes', 'KiB', 'MiB', 'GiB', 'TiB');

        return round(pow(1024, $base - floor($base)), 2) . ' ' . $suffixes[floor($base)]; // todo localize
    }

    public function getFormattedID(): string
    {
        return Snowflake::format($this->idHat);
    }

    public function jsonSerialize(): object
    {
        return (object)[
            'idHat' => $this->idHat,
            'name' => $this->name,
            'author' => $this->author,
            'approved' => $this->isApproved,
            'created' => $this->created->timestamp,
            'updated' => $this->updated->timestamp
        ];
    }
}