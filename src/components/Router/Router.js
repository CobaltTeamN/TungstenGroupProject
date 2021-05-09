<<<<<<< HEAD
import { BrowserRouter, Switch, Route } from 'react-router-dom';
<<<<<<< HEAD
import Swap from '../swap copy';
import Bank from '../../pages/Bank/Bank';
import DashBoardHome from '../../pages/DashboardHome';
=======
import Swap from '../exchange';
import Bank from '../../pages/Bank/Bank';
import DashBoardHome from '../../pages/dashboard';
import Voting from '../../pages/Voting/Voting';
import Singlevote from '../../pages/Voting/Singlevote';
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
import { BrowserRouter, Switch, Route } from "react-router-dom";
import Swap from "../exchange";
import Bank from "../../pages/Bank/Bank";
import DashBoardHome from "../../pages/dashboard";
import Voting from "../../pages/Voting/Voting";
import Singlevote from "../../pages/Voting/Singlevote";
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2

export default function Router() {
  return (
    <>
      <Switch>
<<<<<<< HEAD
<<<<<<< HEAD
=======
        <Route exact path="/singlevote" component={Singlevote}/> 
        <Route exact path="/voting" component={Voting}/> 
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
        <Route exact path="/singlevote" component={Singlevote} />
        <Route exact path="/voting" component={Voting} />
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
        <Route path="/chromium" component={Swap} />
        <Route path="/" component={DashBoardHome} />
      </Switch>
    </>
  );
}
