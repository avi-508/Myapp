# Avinash Chowdary Bodduluri - Simple ASP.NET MVC Web Application
---
## Part 1 : Web Application 
A have used default ASP.NET MVC template in Visual Studio Code & Added webform, where user can send in a message or request to App admin.

### Features
- Responsive design using Bootstrap
- Contact Us page with form validation
- Thank you page after successful form submission
- Clean architecture following MVC pattern

### Prerequisites
- [.NET 9.0 SDK](https://dotnet.microsoft.com/en-us/download)
- [Visual Studio Code](https://code.visualstudio.com/)

### Link to the repository
- [Myapp Git Repo](https://github.com/avi-508/Myapp)

### Run the application
- Clone the Git Repo in VS code on any Windows computer
- Open Terminal & run the following command.
```bash
dotnet run
```
### Port 1337 is set as default
- The application will start at `https://localhost:1337` and `http://localhost:1337`.

### Project Structure
- `Controllers/`: Contains all controller classes
  - `HomeController.cs`: Handles home page requests
  - `ContactController.cs`: Handles contact form submissions
- `Models/`: Contains data models
  - `ContactViewModel.cs`: Model for contact form data
  - `ErrorViewModel.cs`: Model for Errors - from MVC Template
- `Views/`: Contains all view templates
  - `Home/`: Views for the home controller
  - `Contact/`: Views for the contact controller
  - `Shared/`: Shared layout views

### Contact Form Implementation & Form Processing
- The Contact Us page contains: Form with validation for required fields and email format
```code
  public class ContactViewModel
    {
        [Required(ErrorMessage = "Name is required")]
        [StringLength(20, ErrorMessage = "Name cannot exceed 20 characters")]
        public string? Name { get; set; }
        
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        [RegularExpression("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", ErrorMessage = "Missing top level domain")]
        public string? Email { get; set; }
        
        [Required(ErrorMessage = "Subject is required")]
        [StringLength(20, ErrorMessage = "Name cannot exceed 20 characters")]
        public string? Subject { get; set; }
        
        [Required(ErrorMessage = "Message is required")]
        [StringLength(500, ErrorMessage = "Message cannot exceed 500 characters")]
        public string? Message { get; set; }
    }
```
- Redirect to a thank you page after successful submission
```code
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
```
- To further implement actual email sending or database storage, we can modify the `Submit` action in `ContactController.cs`.
### Screenshots 
-![Screenshot 2025-03-02 215054](https://github.com/user-attachments/assets/56298c83-f3d6-4afa-9757-bdf500390264)
-![Screenshot 2025-03-02 215110](https://github.com/user-attachments/assets/1804843e-438c-440e-9104-15a736e6a29a)
-![Screenshot 2025-03-02 215126](https://github.com/user-attachments/assets/1d698c2b-1d21-4cf0-85b0-20bb21fb160e)
-![Screenshot 2025-03-02 215151](https://github.com/user-attachments/assets/08e7cf6e-8399-4bf3-8191-6d12bdc8156b)


---
## Part 2: 
### Acknowledgments

- [ASP.NET Core Documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [Bootstrap Documentation](https://getbootstrap.com/docs/)
