'use strict';

angular
  .module('sitemapGeneratorApp', [
    'ngCookies',
    'ngResource',
    'ngSanitize',
    'ngRoute',
    'sitemapServices'
  ])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
  });
