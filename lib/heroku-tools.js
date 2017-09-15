'use babel';

import HerokuLoginView from './heroku-login-view';
import HerokuDeployView from  './heroku-deploy-view';
import Menu from './menu';
import { isLoggedIn, login, logout } from './util';
import { CompositeDisposable } from 'atom';
import Heroku from 'heroku-client';

export default {

  modalPanel: null,
  subscriptions: null,

  activate() {
    Menu.update();

    this.subscriptions = new CompositeDisposable();
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'heroku:login': () => this.doLogin(),
      'heroku:logout': () => this.doLogout(),
      'heroku:deploy': () => this.doDeploy(),
      'core:cancel': () => this.doCloseModal(),
      'core:close': () => this.doCloseModal()
    }));
  },

  deactivate() {
    this.subscriptions.dispose();
    this.doCloseModal();
  },

  doLogin() {
    const herokuLoginView = new HerokuLoginView();
    this.modalPanel = atom.workspace.addModalPanel({
      item: herokuLoginView
    });
  },

  doLogout() {
    logout();
    Menu.update();
  },

  doDeploy() {
    const herokuDeployView = new HerokuDeployView();
    this.modalPanel = atom.workspace.addModalPanel({
      item: herokuDeployView
    });
  },

  doCloseModal() {
    if (this.modalPanel != null) {
      this.modalPanel.destroy();
    }
  }

};
