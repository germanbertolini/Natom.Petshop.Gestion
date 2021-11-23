using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Primitives;
using Natom.Petshop.Gestion.Biz;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Backend.Controllers
{
    public class BaseController : ControllerBase
    {
        protected IServiceProvider _serviceProvider;
        protected IConfiguration _configuration;
        protected BizDbContext _db;
        protected string _userAgent;

        public BaseController(IServiceProvider serviceProvider)
        {
            var httpContextAccessor = (IHttpContextAccessor)serviceProvider.GetService(typeof(IHttpContextAccessor));
            _serviceProvider = serviceProvider;
            _db = (BizDbContext)serviceProvider.GetService(typeof(BizDbContext));
            _configuration = (IConfiguration)serviceProvider.GetService(typeof(IConfiguration));
            _userAgent = httpContextAccessor.HttpContext.Request.Headers["User-Agent"];
        }

        protected string GetAuthorizationFromHeader()
        {
            string authorization = null;
            StringValues stringValues;
            if (Request.Headers.TryGetValue("Authorization", out stringValues))
                authorization = stringValues.FirstOrDefault();
            return authorization;
        }
    }
}
