'use strict';

describe('Service: Sitemapservice', function () {

  // load the service's module
  beforeEach(module('sitemapGeneratorApp'));

  // instantiate service
  var Sitemapservice;
  beforeEach(inject(function (_Sitemapservice_) {
    Sitemapservice = _Sitemapservice_;
  }));

  it('should do something', function () {
    expect(!!Sitemapservice).toBe(true);
  });

});
