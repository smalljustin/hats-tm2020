<?php

/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

namespace Handler;

use Snowflake;

class APISetHat extends \HandlerBase
{

    public static function registerRoutes(): array
    {
        return [
            ['POST', '/api/sethat']
        ];
    }

    public function respond(array $vars)
    {
        try {
            $body = json_decode(file_get_contents('php://input'));
            if (json_last_error() != JSON_ERROR_NONE) {
                throw new \Exception();
            }
        } catch (\Throwable $e) {
            $this->apiError(json_last_error_msg(), 400, json_last_error());
            return;
        }

        try {
            $user = \User::createFromAPIKey($this->trs, trim($body->apiKey));
        } catch (\InvalidArgumentException $e) {
            $this->apiError("Unable to authenticate user, please recycle your API token", 401);
            return;
        }

        try {
            $hat = \Hat::createFromID($this->trs, Snowflake::Parse($body->idHat ?? null));

            if (!$hat->isApproved) {
                $this->apiError("Unable to set unapproved hats", 401);
                return;
            }

            $user->hat = $hat;
            $user->update();
            $this->trs->log("user_sethat", $hat->idHat, user: $user);

            header("Content-Type: application/json");
            echo json_encode($user);
        } catch (\Throwable $e) {
            $this->apiError("Unknown map parse error. Please try again", 500, $e->getMessage());
        }
    }
}
