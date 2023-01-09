<?php

/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

namespace Handler;

use Hat;

class HatDataHandler extends \HandlerBase
{

    public static function registerRoutes(): array
    {
        return [
            [['GET'], '/hats/{idHat}/data']
        ];
    }

    public function respond(array $vars)
    {

        try {
            $hat = Hat::createFromID($this->trs, \Snowflake::parse($vars['idHat']));
        } catch (\InvalidArgumentException) {
            $this->errorMessage("Unkown hat");
            return;
        } catch (\Throwable) {
            $this->errorMessage("Unknown error creating hat object");
            return;
        }

        header("Content-Type: media/obj");
        header('Content-Disposition: attachment; filename="tm-hats_' . $hat->getFormattedID() . '.obj"');

        echo $hat->data;


    }
}
