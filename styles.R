
# Custom login page style --------
loginPageStyle <-
  "
        body {
        background: #ffcccb; /* Changed background to a light coral */
        background: -webkit-linear-gradient(to bottom, #ffcccb, #f5f5f5); /* Chrome 10-25, Safari 5.1-6 */
        background: linear-gradient(to bottom, #ffcccb, #f5f5f5); /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */
        color: #222222; /* Darker gray text */
        font-family: 'Verdana', sans-serif; /* Updated font to Verdana */
      }
      #login-page {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background-color: #ffebcd; /* Lightened background for the login container */
        border: 1px solid #ddd;
        border-radius: 12px; /* Slightly increased border-radius */
        padding: 45px; /* Increased padding for more space */
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15); /* Slightly stronger shadow */
        text-align: center;
        max-width: 420px; /* Increased max-width */
      }
      .login-header {
        margin-bottom: 35px; /* Increased space below header */
        font-size: 26px; /* Increased font size */
        color: #444444; /* Slightly darker header color */
      }
      .form-group {
        margin-bottom: 25px; /* Increased margin for more spacing */
      }
      .btn-primary {
        background-color: #4CAF50; /* Changed button color to green */
        color: #fff;
        border-color: #4CAF50;
        transition: all 0.3s ease;
      }
      .btn-primary:hover {
        background-color: #388E3C; /* Darkened hover color */
        border-color: #388E3C;
      }
    "


# Style for notifications
global_modal_style <- HTML("
  /* Add your custom styles here */
  .modal-header {
    background-color: #4898a8; /* Set the background color of the header */
    color: white; /* Set the text color of the header */
  }
  .modal-footer {
    background-color: #4898a8; /* Set the background color of the footer */
  }
")


# style for logout button
logout_button_style <- "background-color: white !important; border: 0; border-radius: 20px; font-weight: bold; margin:5px; padding: 10px;"

buttonStyle <- function(button_width){
  run_query_button <- glue::glue("color: #fff; background-color: #17a2b8; border-color: #17a2b8; width: {button_width}px; height: 35px; border-radius: 20px; border: 2px solid #17a2b8;")
}
