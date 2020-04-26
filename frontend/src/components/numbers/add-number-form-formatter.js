import React from 'react'

const AddNumberFormFormatter = ({ onSubmit, onChange, nextNumber }) => (
  <form onSubmit={onSubmit}>
    <input type="text" id="number" value={nextNumber} onChange={onChange} />
    <button type="submit">ADD</button>
  </form>
);

export default AddNumberFormFormatter
