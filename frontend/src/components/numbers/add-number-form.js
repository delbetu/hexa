import React, { Component } from 'react'
import { connect  } from "react-redux"
import { addNumberAction, setNextNumberAction } from '../../actions'
import AddNumberFormFormatter from './add-number-form-formatter'

function mapDispatchToProps(dispatch) {
  return {
    addNumber: n => dispatch(addNumberAction(n)),
    setNextNumber: n => dispatch(setNextNumberAction(n))
  }
}

const mapStateToProps = state => {
  return {
    numbers: state.numbers,
    nextNumber: state.nextNumber,
  }
};

class ConnectedForm extends Component {
  constructor(props) {
    super(props)
    this.handleChange = this.handleChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }
  handleChange(event) {
    this.props.setNextNumber(event.target.value)
  }
  handleSubmit(event) {
    event.preventDefault()
    this.props.addNumber(this.props.nextNumber)
  }

  render() {
    return (
      <AddNumberFormFormatter
        onSubmit={this.handleSubmit}
        onChange={this.handleChange}
        nextNumber={this.props.nextNumber}
      />
    )
  }
}

const AddNumberForm = connect(
  mapStateToProps,
  mapDispatchToProps
)(ConnectedForm)

export default AddNumberForm
