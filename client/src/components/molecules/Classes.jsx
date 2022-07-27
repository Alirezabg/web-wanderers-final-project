import { useEffect, useState } from "react";
import ClassRow from "./ClassRow";
import _ from "lodash"

const Classes = () => {
  const [data, setData] = useState([]);

	useEffect(() => {
		getData();
	}, []);

	const getData = async() =>
	{
		const res = await fetch("http://localhost:8000/api/week");
		const data = await res.json();

		setData(data);
	};


  return (
    <>
      <h2 class="text-center fw-bold">Availabe Dates and Slots</h2>
      <div class="row d-flex justify-content-center m-3 mb-5">
        {_.map(data, (oneClass, index) => (
          <ClassRow
            key={index}
            available={oneClass.openSlots}
            date={oneClass.weekDate}
            filled={oneClass.filledSlots}
            
          />
        ))}
      </div>
    </>
  );
};
export default Classes;
