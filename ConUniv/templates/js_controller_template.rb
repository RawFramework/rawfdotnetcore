def js_controller_template model
    name = model['name']
return <<template
define(['jquery', 'utils'], function ($, utils) {
    var ajaxCalls = {};
    var baseUrl = "/#{name}", //This is the controller on MVC%
        get#{name}sUrl = baseUrl + "/Get#{name}s", //this is the method on the MVC5 controller
        get#{name}Url = baseUrl + "/Get#{name}";
    
    function get#{name}s() {
        return utils.makeAjaxCall(get#{name}sUrl);
    }
    
    function get#{name}(id) {
        var data = {
            id: id    
        };
        
        return utils.makeAjaxCall(get#{name}Url, data);
    }
    
    ajaxCalls = {
        get#{name}s: get#{name}s,
        get#{name}: get#{name}
    };


    return ajaxCalls;
});
template
end