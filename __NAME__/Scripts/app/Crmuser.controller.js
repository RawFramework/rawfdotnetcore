define(['jquery', 'utils', 'growl'], function ($, utils, growl) {
    var ajaxCalls = {};
    var baseUrl = "/Crmuser", //This is the controller on MVC%
        getCrmusersUrl = baseUrl + "/GetCrmusers", //this is the method on the MVC5 controller
        postForgotPasswordUrl = baseUrl + "/ForgotPassword", //this is the method on the MVC5 controller
        getCrmuserUrl = baseUrl + "/GetCrmuser";
        
    
    function getCrmusers() {
        return utils.makeAjaxCall(getCrmusersUrl);
    }
    
    function getCrmuser(id) {
        var data = {
            id: id    
        };
        
        return utils.makeAjaxCall(getCrmuserUrl, data);
    }
    
    ajaxCalls = {
        getCrmusers: getCrmusers,
        getCrmuser: getCrmuser
    };


    return ajaxCalls;
});
