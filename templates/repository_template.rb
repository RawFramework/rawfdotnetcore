def repository_template name, keytype, entityNameSpace
    name_downcase = name.downcase
return <<template
using Needletail.DataAccess;
using Needletail.DataAccess.Engines;
using Needletail.DataAccess.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using #{entityNameSpace};

namespace #{@solution_name_sans_extension}.Repositories
{
    
    public class #{name}Repository : RepositoryBase<#{name},#{keytype}>
    {

        //Overrride base methods to add custom business logic in here
    }
}
template
end