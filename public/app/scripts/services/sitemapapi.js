'use strict';
var hostname = 'http://localhost:8080/api';

var sitemapServices = angular.module('sitemapServices', ['ngResource']);

sitemapServices.factory('Sitemap', ['$resource',
  function($resource){
    return $resource(hostname + '/sitemap/:website', {}, {
      query: {method:'GET'},
      dummy: {method:'GET', url: hostname + '/dummy'}
    });
  }]);