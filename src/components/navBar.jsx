import React from "react";
import { Navbar, Nav, NavDropdown } from "react-bootstrap";
import "./navBar.css";

export default function NavBar(props) {
  return (
    <header>
      <Navbar className="navgroup" collapseOnSelect expand="lg">
        <Navbar.Brand href="#home" className="ml-2">
          <Navbar.Toggle aria-controls="responsive-navbar-nav" />
          <img
            className="nav-logo"
            alt="logo"
            width="50px"
            src="https://miro.medium.com/max/4800/1*-k-vtfVGvPYehueIfPRHEA.png"
          />
        </Navbar.Brand>
        <Nav className="justify-content-end align-items-center ml-auto">
          {/* <Nav.Link href="#deets">
            <button className="navbtn tour" onClick={props.openTour}>
              Take A Tour
            </button>
          </Nav.Link>
          <Nav.Link href="#memes">
            {" "}
            <button className="cblt">
              <span>{20000 + " CBLT"}</span>
            </button>
          </Nav.Link>
          <Nav.Link href="#memes">
            {" "}
            <button className="navbtn ">
              <span>{3000 + " ETH"}</span>
            </button>
          </Nav.Link> */}
          <NavDropdown
            className="navbtn settings mr-2"
            title="..."
            id="collasible-nav-dropdown"
          >
            <NavDropdown.Item href="#action/3.2"></NavDropdown.Item>
            <NavDropdown.Item href="#action/3.2"></NavDropdown.Item>
            <NavDropdown.Divider />
            <NavDropdown.Item href="#action/3.4">
              Separated link
            </NavDropdown.Item>
          </NavDropdown>
        </Nav>
      </Navbar>
    </header>
  );
}
