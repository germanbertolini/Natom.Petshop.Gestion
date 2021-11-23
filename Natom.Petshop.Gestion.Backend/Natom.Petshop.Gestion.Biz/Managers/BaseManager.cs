using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Biz.Managers
{
    public class BaseManager
    {
        protected IServiceProvider _serviceProvider;
        protected IConfiguration _configuration;
        protected BizDbContext _db;

        public BaseManager(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
            _db = (BizDbContext)_serviceProvider.GetService(typeof(BizDbContext));
            _configuration = (IConfiguration)serviceProvider.GetService(typeof(IConfiguration));
        }
    }
}
