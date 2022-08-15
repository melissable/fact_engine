import React from "react";
import { BallTriangle } from "react-loader-spinner";

export default function Spinner({on, children, className, displayStyle}) {
  if (on) {
    return (
      <div className={className || "text-center"}>
        <div style={{ display: displayStyle || "block", margin: "auto", width: "130px" }}>
          <BallTriangle
            color="#00BFFF"
            visible={true}
          />
        </div>
      </div>
    );
  }
  return children;
}