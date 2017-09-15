'use babel';

import { loggedInEmail } from './util';

export default {

  update() {
    const herokuMenu = atom.menu.template.find(t => t.label == 'Heroku');

    loggedInEmail()
      .then(email => {
        herokuMenu.submenu = [
          {
            label: 'Deploy this project',
            command: 'heroku:deploy'
          },
          {
            label: 'Logout ' + email,
            command: 'heroku:logout'
          }
        ];
        atom.menu.update();
      })
      .catch(e => {
        herokuMenu.submenu = [
          {
            label: 'Login',
            command: 'heroku:login'
          }
        ];
        atom.menu.update();
      });
  }

};
