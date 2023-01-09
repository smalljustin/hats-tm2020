<?php

/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

namespace Handler;

class AddHatHandler extends \HandlerBase
{

    public static function registerRoutes(): array
    {
        return [
            [['POST', 'GET'], '/hats']
        ];
    }

    public function respond(array $vars)
    {
        if (!$this->trs->user->isLogged) {
            $this->unauthorizedMessage();
            return;
        }

        $vars['breadcrumb'] = [
            '/' => 'Home',
            '/hats' => 'Hats',
        ];

        if (array_key_exists("submit", $_POST)) {
            if (
                !array_key_exists('data', $_FILES)
                || $_FILES['data']['error'] != UPLOAD_ERR_OK
            ) {
                $this->errorMessage("Invalid form submission. Please try again.");
                return;
            }

            if ($_FILES['data']['size'] > \Hat::MAX_HAT_SIZE) {
                $this->errorMessage("Hat too large to fit on your head. Please try a smaller hat size");
                return;
            }
            $hat = new \Hat($this->trs);
            $hat->idHat = \Snowflake::generate();
            $hat->author = $this->trs->user;
            $hat->name = trim($_POST['name']);
            $hat->data = file_get_contents($_FILES['data']['tmp_name']);
            $hat->isApproved = false;

            try {
                $hat->create();
                $vars['friendlyMessage'] = [
                    'Hat uploaded',
                    'Your hat has been submitted for review. If you have questions about this process, talk to us on the Openplanet discord!'
                ];
            } catch (\Throwable $e) {
                $this->errorMessage("Error occurred storing hat. Please try again or seek help.");
            }
        }

        $vars['hats'] = \Hat::getHatsByUser($this->trs, $this->trs->user);

        echo $this->trs->twig->render("personalHatPage.twig", $vars);
    }
}
