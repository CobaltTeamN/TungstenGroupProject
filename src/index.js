<<<<<<< HEAD
import React from 'react';
import ReactDOM from 'react-dom';
<<<<<<< HEAD
// import './index.css';
=======
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
import App from './App';
import NewApp from './NewApp';
=======
import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import NewApp from "./NewApp";
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2

import reportWebVitals from "./reportWebVitals";
import "bootstrap/dist/css/bootstrap.min.css";

ReactDOM.render(
  <React.StrictMode>
    <NewApp />
  </React.StrictMode>,
  document.getElementById("root")
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
