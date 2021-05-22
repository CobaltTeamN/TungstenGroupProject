import { Switch, Route } from "react-router-dom";
import Swap from "../exchange";
// import Bank from '../../pages/Bank/Bank';
import DashBoardHome from "../../pages/dashboard";
import ChromiumApp from "../../pages/Exchange/ChromiumApp";
import Voting from "../../pages/Voting/Voting";
import Singlevote from "../../pages/Voting/Singlevote";
import NFT from "../../pages/NFT/NFT";
import Chronicles from "../../pages/Chronicles/Chronicles";
import Collections from "../../pages/Colletions/Collections";
import Catalyst from "../../pages/Catalyst/Catalyst";
import { DataProvider } from "../../GlobalState";

export default function Router() {
  return (
    <>
      <Switch>
        <DataProvider>
          <Route exact path="/NFT" component={NFT} />
          <Route exact path="/singlevote" component={Singlevote} />
          <Route exact path="/voting" component={Voting} />
          <Route exact path="/chromium" component={Swap} />
          <Route exact path="/hugo" component={ChromiumApp} />
          <Route exact path="/catalyst" component={Catalyst} />
          <Route exact path="/chronicles" component={Chronicles} />
          <Route exact path="/collections" component={Collections} />
          <Route exact path="/" component={DashBoardHome} />
        </DataProvider>
      </Switch>
    </>
  );
}
