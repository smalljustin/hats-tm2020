<?php

/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

namespace Handler;

class HatReviewHandler extends \HandlerBase
{

    public static function registerRoutes(): array
    {
        return [
            [['POST', 'GET'], '/hats/queue']
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

        $vars['hats'] = \Hat::getAllHats($this->trs);

        echo $this->trs->twig->render("hatReview.twig", $vars);
    }
}
