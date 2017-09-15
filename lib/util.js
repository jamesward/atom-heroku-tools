'use babel';

import Heroku from 'heroku-client';
import Netrc from 'netrc2';
import HerokuSourceDeployer from 'heroku-source-deployer';

export default {

  async loggedInEmail() {
    const machines = Netrc();
    const herokuAuth = machines['api.heroku.com'];

    if ((herokuAuth != undefined) && (herokuAuth.length == 2)) {
      const herokuToken = herokuAuth[1];
      const heroku = new Heroku({
        token: herokuToken
      });

      return heroku.get('/account').then(data => data.email);
    }
    else {
      return Promise.reject('No netrc values for Heroku');
    }
  },

  async apps() {
    const machines = Netrc();
    const herokuAuth = machines['api.heroku.com'];

    if ((herokuAuth != undefined) && (herokuAuth.length == 2)) {
      const herokuToken = herokuAuth[1];
      const heroku = new Heroku({
        token: herokuToken
      });

      return heroku.get('/apps');
    }
    else {
      return Promise.reject('No netrc values for Heroku');
    }
  },

  async deploy(name, projectDir) {
    const machines = Netrc();
    const herokuAuth = machines['api.heroku.com'];

    if ((herokuAuth != undefined) && (herokuAuth.length == 2)) {
      const herokuToken = herokuAuth[1]

      atom.notifications.addInfo('Uploading to Heroku...')

      HerokuSourceDeployer.deployDir(herokuToken, name, projectDir).then(deployInfo => {
        const url = 'https://dashboard.heroku.com/apps/' + name + '/activity/builds/' + deployInfo.id;
        if (deployInfo.status == 'pending') {
          atom.notifications.addInfo('The application is building.  Check the build log: ' + url);
          HerokuSourceDeployer.buildComplete(herokuToken, name, deployInfo.id).then(buildResult => {
            if (buildResult.build.status == 'succeeded') {
              atom.notifications.addSuccess('The build completed successfully.  Check the build log: ' + url);
            }
            else {
              atom.notifications.addError('The build failed.  Check the build log: ' + url);
            }
          }).catch(err =>
            atom.notifications.addError('The build failed: ' + err)
          )
        }
        else if (deployInfo.status == 'error') {
          atom.notifications.addError('Error building the application.  Check the build log: ' + url);
        }
      }).catch(err =>
        atom.notifications.addError('Error building the application: ' + err)
      );
    }
    else {
      return Promise.reject('No netrc values for Heroku');
    }
  },

  async login(username, password, maybeSecondFactor) {
    const heroku = new Heroku();

    const options = {
      method: 'POST',
      path: '/oauth/authorizations',
      auth: username + ':' + password,
      headers: {
        'Heroku-Two-Factor-Code': maybeSecondFactor,
      }
    };

    return heroku.request(options)
      .then(data => {
        const accessToken = data.access_token['token'];

        const machines = Netrc();
        machines['api.heroku.com'] = [username, accessToken];
        machines.save();

        return accessToken;
      })
      .catch(e => Promise.reject(e.body.message));
  },

  logout() {
    const machines = Netrc();
    machines['api.heroku.com'] = [null];
    machines.save();
  }

};
