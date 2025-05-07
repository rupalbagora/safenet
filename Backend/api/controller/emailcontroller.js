import nodemailer from 'nodemailer';
//jis user ne register kiya h uska email and password receive kiya h 
// yh function call kha se hoga -  register component se
function sendMail(email,password)
{
    var transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'rupal.bagora@gmail.com',
    pass: 'vlow xotj cgpg upxo'
  }
});

var mailOptions = {
  from: 'rupal.bagora@gmail.com',
  to: 'rupal.bagora@gmail.com',
  subject: 'verify your account',
  html:'<h1>Welcome to Myapp </h1> <p>You have successfully register to our side </p> <h2>Email:'+email+"</h2> <h2> Password : "+password+"</h2><h1> Click on the link below to verify your account </h1> http://localhost:3000/verify/"+email,
 
};

transporter.sendMail(mailOptions, function(error, info){
  if (error) {
    console.log(error);
  } else {
    console.log('Email sent: ' + info.response);
  }
});
}
export default sendMail;