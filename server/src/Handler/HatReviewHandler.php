<?php

/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

namespace Handler;

use Hat;

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

        $vars['hats'] = Hat::getAllHats($this->trs)->sortCustom(function (Hat $a, Hat $b) {
            $app = $a->isApproved <=> $b->isApproved;
            $date = $a->created <=> $b->created;
            if ($app == 0) {
                return $date;
            }
            return $app;
        });

        echo $this->trs->twig->render("hatReview.twig", $vars);
    }
}
