import {
  Drawer,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
} from '@material-ui/core';
import {
  Home,
  SwapHoriz,
  Work,
  Business,
  AccountBalance,
  Description,
  Collections,
  EnhancedEncryption,
} from '@material-ui/icons';
import styled from 'styled-components';
import { Link, useLocation } from 'react-router-dom';

const SidebarItems = [
  { icon: <Home />, text: 'Dashboard', link: '' },
  { icon: <SwapHoriz />, text: 'Exchange', link: '/chromium' },
  { icon: <Work />, text: 'Catalyst', link: '/catalyst' },
  { icon: <Business />, text: 'CBLP', link: '/cblp' },
  { icon: <AccountBalance />, text: 'Borrow', link: '/lend' },
  { icon: <EnhancedEncryption />, text: 'Staking', link: '/staking' },
<<<<<<< HEAD
=======
  { icon: <EnhancedEncryption />, text: 'Voting', link: '/voting' },
  { icon: <EnhancedEncryption />, text: 'Single Vote', link: '/singlevote' },
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
  { icon: <Description />, text: 'Chronicles', link: '/chronicles' },
  { icon: <Collections />, text: 'Cobalt Collections', link: '/cobaltcollections' },
];
const StyledLink = styled(Link)`
  text-decoration: none !important;
  color: inherit;
`;


export default function CustomDrawer() {
  const location = useLocation();
  console.log(location.pathname.substr(1));

  const Lists = SidebarItems.map((item) => {
    return (
      <>
        <StyledLink to={item.link} key={item.text}>
          <ListItem
            style={{
              whiteSpace: 'normal',
              color:
                location.pathname.substr(1) === item.link ? '#5664d2' : 'inherit',
            }}>
            <ListItemIcon
              style={{
                color:
                  location.pathname.substr(1) === item.link
                    ? '#5664d2'
                    : 'inherit',
              }}>
              {item.icon}
            </ListItemIcon>
            <ListItemText primary={item.text} />
          </ListItem>
        </StyledLink>

      </>
    );
  });

  return (
    <>
      <StyledDrawer variant="permanent" anchor="left">
<<<<<<< HEAD
        <img
          src="CobaltLogo.jpg"
          style={{ width: '50%', marginTop: '5%' }}
          alt="logo"
        />
        <StyledDivider />
=======
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
        <StyledList> {Lists}</StyledList>
      </StyledDrawer>
    </>
  );
}

const StyledDrawer = styled(Drawer)`
  margin: 0;
  .MuiDrawer-paper {
<<<<<<< HEAD
=======
    top: auto;
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
    margin-top: 0%;
    padding-top: 5%;
    width: 240px !important;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
`;
const StyledDivider = styled.hr`
  padding: 5px;
  align-self: stretch;
  margin: 4% 0 4% 0;
`;
const StyledList = styled(List)`
  width: 80%;
  border-radius: 10px;
  margin: 0;
`;
