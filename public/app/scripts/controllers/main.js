'use strict';

angular.module('sitemapGeneratorApp')
    .controller('MainCtrl', ['$scope', '$http', 'Sitemap', function ($scope, $http, Sitemap) {

        // Default website
        $scope.website = 'www.onegeek.com.au'

        /**
         * Generate a Sitemap
         */
        $scope.generateSitemap = function (url) {

            var data = Sitemap.getSitemap(url)
            data.then(function (result) {
                console.log(result)
                var sitemap = [];
                for (var i in result) {
                    if (i.indexOf('http') == 0) {
                        sitemap[sitemap.length] = {"href": i, "title": result[i].title};
                    }
                }
                $scope.sitemap = sitemap;
            });
        },

        /**
         * Download the CSV
         */
        $scope.getData = function() {
            var csvContent = 'Link, Title\n';
            for (var i in $scope.sitemap) {
                csvContent += $scope.sitemap[i].href + ',' + $scope.sitemap[i].title + '\n';
            }
            return {'title': 'sitemap', 'content': csvContent}
        }
    }]);