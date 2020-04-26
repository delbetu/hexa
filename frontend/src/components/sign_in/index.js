import React from "react";

const SignIn = () => {
  const [credentials, setCredentials] = React.useState({
    username: "",
    password: ""
  });

  const handleSubmit = creds => {
    console.table(creds);
    setCredentials(creds);
  };

  return (
    <form
      onSubmit={e => {
        e.preventDefault();
        handleSubmit({
          username: e.target.elements["username"].value,
          password: e.target.elements["password"].value
        });
      }}
    >
      <label> Username: </label>
      <input type="text" name="username" />
      <label>Password:</label>
      <input type="password" name="password" />
      <input type="submit" value="Login" />
    </form>
  );
};

export default SignIn;
