'use strict';

angular.module('sitemapGeneratorApp', [])
  .controller('MainCtrl', ['$scope', '$http', function ($scope, $http) {

    $http.get('http://localhost:8080/api/dummy').success(function(data) {
      var sitemap = []
      for (var i in data) {
        // console.log(i)
        var obj = {"href": i, "title": data[i].title}
        sitemap[sitemap.length] = obj
        console.log(obj)
      }

      $scope.sitemap = sitemap;
    });

    alert('aoeu')
  }]);

  // angular.module('sitemapGeneratorApp', ['sitemapServices'])
  // .controller('MainCtrl', ['$scope', '$http', 'Sitemap' function ($scope, $http, Sitemap) {

  //   $http.get('http://localhost:8080/api/dummy').success(function(data) {
  //     var sitemap = []
  //     for (var i in data) {
  //       // console.log(i)
  //       var obj = {"href": i, "title": data[i].title}
  //       sitemap[sitemap.length] = obj
  //       console.log(obj)
  //     }

  //     $scope.sitemap = sitemap;
  //   });
  // });

// angular.module('sitemapGeneratorApp', ['sitemap.services'])
//   .controller('MainCtrl', ['$scope', '$http', 'Sitemap'], function ($scope, $http, Sitemap) {

//     $http.get('http://localhost:8080/api/dummy').success(function(data) {
//       var sitemap = []
//       for (var i in data) {
//         // console.log(i)
//         var obj = {"href": i, "title": data[i].title}
//         sitemap[sitemap.length] = obj
//         console.log(obj)
//       }

//       $scope.sitemap = sitemap;
//     });
//   });
