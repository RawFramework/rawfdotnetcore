def js_bs_grid_template model
	name = model['name']
	name_downcase = name.downcase
	return <<template
define(['jquery', 'bootstrap', 'jqUi', 'bsPagination', 'bsPaginationLocation', 'juiFilter', 'juiFilterLocation', 'jqBsGrid', 'jqBsGridLocation'], function ($) {

$("#bs_grid_#{name_downcase}").bs_grid({
    pageNum: 1,
    rowsPerPage: 3,
    maxRowsPerPage: 5,
    row_primary_key: "Id",
    rowSelectionMode: "single", 
    selected_ids: [],
    ajaxFetchDataURL: "#{name_downcase}/getall#{name_downcase}",
    
    #{get_grid_fields(model)}

    paginationOptions: {
        containerClass: "well pagination-container",
        visiblePageLinks: 2,
        showGoToPage: true,
        showRowsPerPage: true,
        showRowsInfo: true,
        showRowsDefaultInfo: true,
        disableTextSelectionInNavPane: true
    },
    useFilters: false,
    filterOptions: {
        filters: [
            {
            }
        ]
    }

});
});
template
end

def get_grid_fields model
	elements = model.at_xpath("fields").elements
    columns = ""
    sorting = ""
    fields = ""

    elements.each do |node|    
        property_name = node.name
        visibility = (property_name.to_s == "Id") ? ", visible: 'no'" : ""

        columns += "{ field: '#{property_name}', header: '#{property_name}'#{visibility} },
        "
        sorting += "{ sortingName: '#{property_name}', field: '#{property_name}' },
        "
    end

    columns += "{ field: 'edit', header: '' },
    			{ field: 'details', header: '' },
    			{ field: 'delete', header: '' }"

    fields = "
    columns: [
    	#{columns}
    ],

    sorting: [
    	#{sorting}    
    ],
    "

end