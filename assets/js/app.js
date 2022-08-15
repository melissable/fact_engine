import React, { useEffect, useState, Fragment } from "react";
import { Button, Row, Col, Container } from "reactstrap";
import "../css/app.scss";
import "bootstrap/dist/css/bootstrap.min.css";
import _ from "lodash";
import { DebounceInput } from "react-debounce-input";
import Select from "react-select";
import { BsFillPatchCheckFill } from 'react-icons/bs';
import { AiFillCloseCircle } from 'react-icons/ai';

import { FactPopout, Spinner } from "../components";
import { api } from "../utils";

const queryTypes = [
  {
    label: "Species, e.g Is Lucy a cat?",
    value: "species",
    parts: [
      { phrase: "Is ", showInput: true, placeholder: "Lucy" },
      { phrase: "a ", showInput: true, placeholder: "cat" },
      { phrase: "?", showInput: false },
    ],
    requiredInputs: 2,
  },
  {
    label: "Friends, e.g Are Sam and Alex friends?",
    value: "friends",
    parts: [
      { phrase: "Are ", showInput: true, placeholder: "Sam" },
      { phrase: "and ", showInput: true, placeholder: "Alex" },
      { phrase: "friends?", showInput: false },
    ],
    requiredInputs: 2,
  },
];

export default function App() {
  const [response, setResponse] = useState(null);
  const [loading, setLoading] = useState(false);
  const [queryType, setQueryType] = useState(queryTypes[0]);
  const [inputs, setInputs] = useState([]);

  function processData() {
    if (!loading && inputs && inputs.length === queryType.requiredInputs) {
      setLoading(true);
      let payload = {
        queryType: queryType.value,
        inputs: inputs,
      };
      console.log("payload", payload);
      api
        .post("query_facts", payload)
        .then((res) => {
          if (res && res.data && res.data.success) {
            setResponse(res.data.match);
          } else {
            setResponse(null);
          }
        })
        .catch(api.catchHandler)
        .finally(() => setLoading(false));
    }
  }

  function onChange(index, changes) {
    let responses = _.assign([], inputs);
    responses[index] = changes;
    console.log("resopsoeikrn", responses, index);
    setInputs(responses);
  }

  return (
    <Container>
      <FactPopout />
      <Row className="mb-2">
        <Col>
          <h1>Fact Engine</h1>
        </Col>
      </Row>
      <Row className="mb-2">
        <Col>
          <h2>What would you like to know?</h2>
        </Col>
        <Col>
          <Select
            options={queryTypes}
            value={queryType}
            onChange={(selection) => {
              setQueryType(selection);
              setInputs([]);
            }}
          />
        </Col>
      </Row>
      <Row className="mb-2">
        {queryType && queryType.parts
          ? _.map(queryType.parts, (p, index) => {
              return (
                <Fragment key={`question${index}`}>
                  <Col>
                    <strong className="d-inline">{p.phrase}</strong>
                  </Col>
                  <Col>
                    {p.showInput && (
                      <DebounceInput
                        value={inputs[index]}
                        onChange={(e) => onChange(index, e.target.value)}
                        className="d-inline"
                        placeholder={p.placeholder}
                        debounceTimeout={500}
                      />
                    )}
                  </Col>
                  <Col>
                    {index + 1 < queryType.parts.length ? null : (
                      <Button disabled={loading} onClick={processData}>
                        Query
                      </Button>
                    )}
                  </Col>
                </Fragment>
              );
            })
          : null}
      </Row>
      {loading ? (
        <Spinner />
      ) : (
        <Row className="text-start">
          <Col>
          {console.log('response', response)}
            {_.isBoolean(response) ? (
              <>
                {response ? (
                  <BsFillPatchCheckFill size="6em" className="resultMatch" />
                ) : (
                  <AiFillCloseCircle size="6em" className="resultNoMatch" />
                )}
              </>
            ) : null}
          </Col>
        </Row>
      )}
    </Container>
  );
}
