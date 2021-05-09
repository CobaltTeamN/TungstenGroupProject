import React from "react";
<<<<<<< HEAD
<<<<<<< HEAD
import { Navbar, Nav, NavDropdown, NavItem } from "react-bootstrap";
import "./navBar.css";

export default function NavBar(props) {
  // let account = props.account;
  // let length = props.account.length;
  // let accountTruncatedFrist = account.substring(0, 5);
  // let accountTruncatedLast = account.substring(length - 5, length);
  // let accountTruncated = accountTruncatedFrist + "..." + accountTruncatedLast;
=======
=======
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
import { Navbar, Nav, NavDropdown } from "react-bootstrap";
import "./navBar.css";

export default function NavBar(props) {
<<<<<<< HEAD
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
  return (
    <header>
      <Navbar className="navgroup" collapseOnSelect expand="lg">
        <Navbar.Brand href="#home" className="ml-2">
<<<<<<< HEAD
<<<<<<< HEAD
          <img
=======
          <Navbar.Toggle aria-controls="responsive-navbar-nav" />
          <img
            className="nav-logo"
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
          <Navbar.Toggle aria-controls="responsive-navbar-nav" />
          <img
            className="nav-logo"
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
            alt="logo"
            width="50px"
            src="https://miro.medium.com/max/4800/1*-k-vtfVGvPYehueIfPRHEA.png"
          />
        </Navbar.Brand>
<<<<<<< HEAD
<<<<<<< HEAD
        <Navbar.Toggle aria-controls="responsive-navbar-nav" />
        <Navbar.Collapse id="responsive-navbar-nav">
          <Nav className="mr-auto ">
            <Nav.Item onClick={(e) => props.handleRender("swap")}>
              Swap
            </Nav.Item>
            <Nav.Item onClick={(e) => props.handleRender("treasury")}>
              Exchange
            </Nav.Item>
            <Nav.Item onClick={(e) => props.handleRender("loan")}>
              Loan
            </Nav.Item>
            <Nav.Item onClick={(e) => props.handleRender("exchange")}>
              Treasury
            </Nav.Item>
            <Nav.Item onClick={(e) => props.handleRender("voting")}>
              Voting
            </Nav.Item>
          </Nav>
=======
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
          <Nav className="justify-content-end align-items-center">
            <Nav.Link href="#deets">
              <button className="navbtn tour" onClick={props.openTour}>
                Take A Tour
              </button>
            </Nav.Link>
<<<<<<< HEAD

=======
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
            <Nav.Link href="#memes">
              {" "}
              <button className="cblt">
                <span>{20000 + " CBLT"}</span>
              </button>
            </Nav.Link>
            <Nav.Link href="#memes">
              {" "}
              <button className="navbtn ">
                <span>
                  {3000 +
                    " " +
                    " " +
                    "ETH"}
                </span>
              </button>
            </Nav.Link>
<<<<<<< HEAD
            <Nav.Link href="#memes">
              {" "}
              <button
                // onClick={() => {
                //   navigator.clipboard.writeText(account);
                // }}
                className="navbtn eth"
              >
                {"0982kjsndkjsnjn"}
              </button>
            </Nav.Link>
=======
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
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
<<<<<<< HEAD
        </Navbar.Collapse>
=======
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
        <Nav className="justify-content-end align-items-center">
          <Nav.Link href="#deets">
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
              <span>{3000 + " " + " " + "ETH"}</span>
            </button>
          </Nav.Link>
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
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
      </Navbar>
    </header>
  );
}
