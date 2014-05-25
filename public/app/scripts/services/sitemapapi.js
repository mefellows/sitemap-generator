'use strict';
// var hostname = 'http://localhost:8080/api/';

// angular.module('sitemap.services', ['ngResource'])
//   .factory('Sitemap', ['$resource',
//     function ($resource) {
//         return $resource(hostname + '/sitemap/:website', {}, {
//             query: {method: 'GET', params: {depth: '-1'}, isArray: false}
//         });
//     }]);

// angular.module('sitemap.services')
//   .factory('Sitemap', [
//     function ($resource) {
//         return "aoeu"
//     }]);

// var scanmarkServices = angular.module('sitemap.services', ['ngResource']);
// scanmarkServices.factory('User', ['$resource',
//     function ($resource) {
//         return $resource('hostname' + '/users/:userId', {}, {
//             query: {method: 'GET', params: {userId: 'users'}, isArray: false}
//         });
//     }]);


var sitemapServices = angular.module('sitemapServices', ['ngResource']);

sitemapServices.factory('Sitemap', ['$resource',
  function($resource){
    return $resource('http://localhost:8080/api/sitemap/:website', {}, {
      query: {method:'GET', params:{sitemapId:'sitemaps'}, isArray:true}
    });
  }]);