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

export default function Router() {
  return (
    <>
      <Switch>
<<<<<<< HEAD
=======
        <Route exact path="/singlevote" component={Singlevote}/> 
        <Route exact path="/voting" component={Voting}/> 
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
        <Route path="/chromium" component={Swap} />
        <Route path="/" component={DashBoardHome} />
      </Switch>
    </>
  );
}
