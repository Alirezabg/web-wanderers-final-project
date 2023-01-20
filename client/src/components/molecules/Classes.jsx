import { useEffect, useState } from "react";
import ClassRow from "./ClassRow";
import _ from "lodash";

const Classes = () => {
  const [data, setData] = useState([]);

	const API_PATH =
    process.env.REACT_APP_API_PATH || "http://192.168.1.40:4000/api/";

  useEffect(() => {
    getData();
  }, []);

  const getData = async () => {
    const res = await fetch(API_PATH + "week");
    const data = await res.json();

    setData(data);
  };

  return (
    <>
      <h2 className="text-center fw-bold">Availabe Dates and Slots</h2>
      <div className="row d-flex justify-content-center mb-5">
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
