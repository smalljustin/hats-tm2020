<?php

/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

namespace Handler;

use Hat;

class ApproveHatHandler extends \HandlerBase
{

    public static function registerRoutes(): array
    {
        return [
            [['GET'], '/hats/{idHat}/approve']
        ];
    }

    public function respond(array $vars)
    {
        if (!$this->trs->user->isLogged || !$this->trs->user->isModerator) {
            $this->unauthorizedMessage();
            return;
        }

        $vars['breadcrumb'] = [
            '/' => 'Home',
            '/hats' => 'Hats',
            '/hats/queue' => 'Hat Review',
        ];

        try {
            $hat = Hat::createFromID($this->trs, \Snowflake::parse($vars['idHat']));
        } catch (\InvalidArgumentException) {
            $this->errorMessage("Unkown hat");
            return;
        } catch (\Throwable) {
            $this->errorMessage("Unknown error creating hat object");
            return;
        }

        $hat->isApproved = true;
        $hat->update();
        $this->trs->log("hat_approve", $hat->idHat);

        header("Location: /hats/queue");
    }
}
