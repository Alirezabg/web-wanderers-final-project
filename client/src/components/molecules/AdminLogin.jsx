import React, { useState } from "react";
import Button from "../atoms/Button";
const AdminLogin = ({ setToken}) => {
  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });

  const [error, setError] = useState(false);

  const handleChange = (event) => {
    const newFormData = {
      ...formData,
      [event.target.name]: event.target.value,
    };
    setFormData(newFormData);
  };

	const API_PATH =
    process.env.REACT_APP_API_PATH || "http://192.168.1.40:4000/api/";

  const handleLoginSubmit = async (event) => {
   
    if (validateForm()) {
        event.preventDefault();
      try {
        const res= await fetch(API_PATH + "auth/login", {
 
         method: "POST",
         headers: { "Content-Type": "application/json" },
         body: JSON.stringify(formData),
        });
        const resData = await res.json();
      
        if(res.status!==200){
         setError(resData.msg);
    
        }else{
         const token = { token: resData.token , email:formData.email,userType:resData.type};
         setToken(token);
         //setAdminType(resData.type);
       } 

     } catch (error) {
       console.log("Error", error);
       setError(error);
     }
   }
  }

   const validateForm = () => {
    if (!formData.email || !formData.password) {
      setError("It's mandatory to fill up all fields");
      return false}
  
    if (!formData.email.match(/^([\w.%+-]+)@([\w-]+\.)+([\w]{2,})$/i)) {
      setError("Please enter the valid email address");
      return false;

   } else {
      setError("");
      return true;
    }
  };

  return (
    <div className="login-sigUp-container">
      <div className="admin-form-container">
        <h3>Login</h3>
        <p>Welcome back, Please log in to your account</p>
        <form className="admin-form" onSubmit={handleLoginSubmit}>
          <label>Email</label>
          <input
            placeholder="Enter your email"
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
          />

          <label>Password</label>
          <input
            placeholder="Choose a password"
            type="password"
            name="password"
            value={formData.password}
            onChange={handleChange}
          />
          {error ? <span className="sign-up-err">{error}</span> : null}
          <Button type="submit" className="login-btn" text="Login" />
        </form>
      </div>
    </div>
  );
};

export default AdminLogin;
