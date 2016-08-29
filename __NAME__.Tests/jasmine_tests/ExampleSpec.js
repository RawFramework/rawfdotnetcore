define([], function () {
    describe("A suite is just a function", function () {
        var a;

        it("and so is a spec", function () {
            a = true;

            expect(a).toBe(true);
        });
    });

    describe("example", function () {
        it("should pass", function () {
            expect("jasmine").toBe("jasmine");
        });
    });

});