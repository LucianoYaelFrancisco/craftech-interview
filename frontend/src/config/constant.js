export const BASENAME = ''; // don't add '/' at end off BASENAME
export const BASE_URL = '/app/dashboard/default';
export const BASE_TITLE = ' | Craftech Example App ';

// Determine API_SERVER dynamically based on current host
const getApiServer = () => {
  const protocol = window.location.protocol;
  const hostname = window.location.hostname;
  const port = window.location.port;
  
  // If running on localhost or 127.0.0.1, use separate backend port
  if (hostname === 'localhost' || hostname === '127.0.0.1') {
    return `${protocol}//localhost:8000/api/`;
  }
  
  // If running on ALB or any other domain, use same host with /api path
  const host = port ? `${hostname}:${port}` : hostname;
  return `${protocol}//${host}/api/`;
};

export const API_SERVER = getApiServer();

export const CONFIG = {
    layout: 'vertical', // disable on free version
    subLayout: '', // disable on free version
    collapseMenu: false, // mini-menu
    layoutType: 'menu-dark', // disable on free version
    navIconColor: false, // disable on free version
    headerBackColor: 'header-default', // disable on free version
    navBackColor: 'navbar-default', // disable on free version
    navBrandColor: 'brand-default', // disable on free version
    navBackImage: false, // disable on free version
    rtlLayout: false, // disable on free version
    navFixedLayout: true, // disable on free version
    headerFixedLayout: false, // disable on free version
    boxLayout: false, // disable on free version
    navDropdownIcon: 'style1', // disable on free version
    navListIcon: 'style1', // disable on free version
    navActiveListColor: 'active-default', // disable on free version
    navListTitleColor: 'title-default', // disable on free version
    navListTitleHide: false, // disable on free version
    configBlock: true, // disable on free version
    layout6Background: 'linear-gradient(to right, #A445B2 0%, #D41872 52%, #FF0066 100%)', // disable on free version
    layout6BackSize: '' // disable on free version
};
