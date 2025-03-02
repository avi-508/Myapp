using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Myapp.Models;

namespace Myapp.Controllers
{
    public class ContactController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Submit(ContactViewModel model)
        {
            if (ModelState.IsValid)
            {
                // Process the form submission here
                // E.g., send an email, save to database, etc.
                
                // Redirect to a thank you page or show success message
                return RedirectToAction("ThankYou");
            }
            
            return View("Index", model);
        }

        public IActionResult ThankYou()
        {
            return View();
        }
    }
}