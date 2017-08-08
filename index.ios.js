/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  requireNativeComponent,
  Dimensions
} from 'react-native';

const RNTextAreaMarker = requireNativeComponent(
  'TextAreaMarkerSwift',
  TextAreaMarker
);

class TextAreaMarker extends React.Component {
  render() {
    return <RNTextAreaMarker {...this.props} />;
  }
}

const { height, width } = Dimensions.get('window');

export default class FindText extends Component {
  render() {
    return <TextAreaMarker style={{ width, height }} />;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF'
  }
});

AppRegistry.registerComponent('FindText', () => FindText);
