def js_require_config_template
return <<template
var require = {
    baseUrl: '/Scripts',
    paths: {
        jquery: 'jquery-1.9.1',
        bootstrap: 'bootstrap',
        knockout: 'knockout-3.2.0',
        underscore: 'underscore',
        bootstrapValidator: 'bootstrapValidator',
        utils: 'Utils',
        moment: 'moment',
        bootstrapDateTimePicker: 'bootstrap-datetimepicker',
        bsPagination: "bs_grid/bs_pagination/jquery.bs_pagination.min",
        bsPaginationLocation: "bs_grid/bs_pagination/en.min",
        juiFilter: "bs_grid/jui_filter/jquery.jui_filter_rules.min",
        juiFilterLocation: "bs_grid/jui_filter/en.min",
        jqUi: "bs_grid/jquery-ui.min",
        jqBsGrid: "bs_grid/jquery.bs_grid.min",
        jqBsGridLocation: "bs_grid/en.min"
    }
};
template
end