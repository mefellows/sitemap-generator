'use strict';

angular.module('sitemapGeneratorApp')
    .controller('MainCtrl', ['$scope', '$http', 'Sitemap', 'SocketService', function ($scope, $http, Sitemap, $socketService) {

        $scope.generateSitemap = function (url) {
            var data = $socketService.getResponse({'url': 'http://' + url})

            data.then(function (result) {
                result = result.message
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