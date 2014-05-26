'use strict';

angular.module('sitemapGeneratorApp')
  .controller('MainCtrl', ['$scope', '$http', 'Sitemap', function ($scope, $http, Sitemap) {

    // var data = Sitemap.dummy()


    $scope.generateSitemap = function(url) {

      var data = Sitemap.get({website: url})
      data.$promise.then(function (result) {
        console.log(result)
        var sitemap = [];
        for (var i in result) {
          if (i.indexOf('http') == 0) {
            sitemap[sitemap.length] = {"href": i, "title": result[i].title};
          }
        }
        $scope.sitemap = sitemap;
      });
    }


  }]);