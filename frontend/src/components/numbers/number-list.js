import React, { Component } from "react"
import { connect  } from "react-redux"
import { addNumberAction, addRemoteUserIds } from '../../actions'
import NumberListFormatter from './number-list-formatter'

function mapDispatchToProps(dispatch) {
  return {
    addNumber: n => dispatch(addNumberAction(n)),
    addRemoteUserIds: () => dispatch(addRemoteUserIds())
  }
}

const mapStateToProps = state => {
  return { numbers: state.numbers  }
};

class ConnectedList extends Component {
  constructor(props) {
    super(props)
  }

  componentDidMount() {
    this.props.addRemoteUserIds()
  }

  render() {
    return (<NumberListFormatter numbers={this.props.numbers} />)
  }
}

const NumberList = connect(mapStateToProps, mapDispatchToProps)(ConnectedList)

export default NumberList
