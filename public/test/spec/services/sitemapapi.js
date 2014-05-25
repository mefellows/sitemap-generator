'use strict';

describe('Service: sitemapApi', function () {

  // load the service's module
  beforeEach(module('sitemapGeneratorApp'));

  // instantiate service
  var sitemapApi;
  beforeEach(inject(function (_sitemapApi_) {
    sitemapApi = _sitemapApi_;
  }));

  it('should do something', function () {
    expect(!!sitemapApi).toBe(true);
  });

});
