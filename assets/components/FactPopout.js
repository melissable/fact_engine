import React, { useState, useEffect } from "react";
import {
  Button,
  Offcanvas,
  OffcanvasHeader,
  OffcanvasBody,
  Row,
  Col,
  Nav,
  NavItem,
  NavLink,
  TabContent,
  TabPane,
  ListGroup,
  ListGroupItem,
  Alert,
} from "reactstrap";
import _ from "lodash";
import DebounceInput from "react-debounce-input";
import Select from "react-select";

import { api } from "../utils";
import { Spinner } from ".";

const tabs = {
  CREATURE: "creature",
  FRIENDSHIP: "friendships",
};

export default function FactPopout(props) {
  const [speciesOptions, setSpeciesOptions] = useState([]);
  const [creatures, setCreatures] = useState([]);
  const [newCreature, setNewCreature] = useState(null);
  const [friendships, setFriendships] = useState([]);
  const [newFriendship, setNewFriendship] = useState(null);
  const [dataReady, setDataReady] = useState(false);
  const [open, setOpen] = useState(false);
  const [activeTab, setActiveTab] = useState(tabs.CREATURE);
  const [saving, setSaving] = useState(false);
  const [loaded, setLoaded] = useState(false);
  const [alert, setAlert] = useState(null);

  useEffect(() => {
    api
      .fetch("get_species", {})
      .then((res) => {
        if (res && res.data) {
          setSpeciesOptions(res.data);
        }
      })
      .catch(api.catchHandler)
      .finally(() => setDataReady(true));
  }, []);

  useEffect(() => {
    if (!loaded) {
      refreshData();
    }
  }, [dataReady, loaded]);

  function refreshData() {
    let apiCalls = [
      api.post("get_creatures", {}).then((res) => {
        if (res && res.data) {
          return {
            creatureList: res.data,
          };
        }
      }),
      api.post("get_friendships", {}).then((res) => {
        if (res && res.data) {
          return {
            friendshipList: res.data,
          };
        }
      }),
    ];
    Promise.all(apiCalls)
      .then((arrayResults) => {
        let aggResults = {};
        _.each(arrayResults, (x) => Object.assign(aggResults, x));
        let { creatureList, friendshipList } = aggResults;
        if (creatureList) {
          creatureList =  _.map(creatureList, (x) => {
            x.species = _.find(speciesOptions, (opt) => {
              return opt.value === x.species_id;
            });
            x.label = x.name;
            x.value = x.id;
            return x;
          })        
          setCreatures(creatureList);
        }
        if (friendshipList) {
          friendshipList = _.map(friendshipList, x => {
            x.friend_1 = _.find(creatureList, c => {
              return c.value === x.friend_1_id
            })
            x.friend_2 = _.find(creatureList, c => {
              return c.value === x.friend_2_id
            })
            return x;
          })
          setFriendships(friendshipList);
        }
      })
      .catch(api.catchHandler);
  }

  function onChange(field, value) {
    let changes;
    switch (activeTab) {
      case tabs.CREATURE:
        changes = _.assign({}, newCreature);
        changes[field] = value;
        setNewCreature(changes);
        break;
      case tabs.CREATURE:
      default:
        changes = _.assign({}, newFriendship);
        changes[field] = value;
        setNewFriendship(changes);
        break;
    }
  }

  function saveNew() {
    let payload;
    setAlert(null);
    switch (activeTab) {
      case tabs.CREATURE:
        if (!newCreature || !newCreature.species || !newCreature.name) {
          setAlert("Please add a name and select the species");
          return;
        }
        payload = {
          name: newCreature.name,
          species_id: newCreature.species?.value,
        };
        break;
      case tabs.CREATURE:
      default:
        if (!newFriendship || !newFriendship.friend_1 || !newFriendship.friend_2) {
          setAlert("Please add two friends to the friendship and then save");
          return;
        }
        payload = {
          friend_1_id: newFriendship.friend_1.value,
          friend_2_id: newFriendship.friend_2.value,
        };
        break;
    }
    setSaving(true);
    api
      .post(`save_${activeTab}`, payload)
      .then((res) => {
        if (res && res.data && res.data.success) {
          setNewCreature({
            name: "",
            species: null,
          });
          refreshData();
        }
      })
      .catch(api.catchHandler)
      .finally(() => setSaving(false));
  }

  if (!dataReady)
    return (
      <Spinner
        on={true}
        message="Fetching reference data..."
        className="align-content-center"
      />
    );

  return (
    <div>
      <Button
        color="primary"
        className="popoutButton"
        onClick={() => setOpen(!open)}
      >
        Add new factoids
      </Button>
      <Offcanvas isOpen={open} toggle={() => setOpen(!open)} direction="end">
        <OffcanvasHeader toggle={() => setOpen(!open)} className="bg-light">
          <div className="pt-2 mb-1">Add new factoids</div>
        </OffcanvasHeader>
        <OffcanvasBody>
          {alert ? <Alert color="warning">{alert}</Alert> : null}
          <Row>
            <Col>
              <Nav pills>
                {_.map(tabs, (t) => {
                  return (
                    <NavItem key={`tab${t}`}>
                      <NavLink
                        active={activeTab === t}
                        onClick={() => setActiveTab(t)}
                      >
                        Add new {t}
                      </NavLink>
                    </NavItem>
                  );
                })}
              </Nav>
            </Col>
          </Row>
          <Row>
            <Col>
              <TabContent activeTab={activeTab}>
                <TabPane tabId={tabs.CREATURE}>
                  <Row>
                    <Col sm="12">
                      <ListGroup>
                        <ListGroupItem key="creature-1">
                          <Row>
                            <Col>
                              <DebounceInput
                                value={newCreature?.name}
                                onChange={(e) =>
                                  onChange("name", e.target.value)
                                }
                                placeholder="Enter a name"
                              />
                            </Col>
                            <Col>
                              <Select
                                value={newCreature?.species}
                                onChange={(selection) =>
                                  onChange("species", selection)
                                }
                                options={speciesOptions}
                                placeholder="Pick the species"
                              />
                            </Col>
                            <Col>
                              <Button
                                onClick={() => saveNew()}
                                disabled={saving}
                                children="Save"
                              />
                            </Col>
                          </Row>
                        </ListGroupItem>
                        {_.map(creatures, (c, index) => {
                          return (
                            <ListGroupItem key={`creature${index}`}>
                              <Row>
                                <Col>{c.name}</Col>
                                <Col>
                                  <i>{c.species?.label}</i>
                                </Col>
                              </Row>
                            </ListGroupItem>
                          );
                        })}
                      </ListGroup>
                    </Col>
                  </Row>
                </TabPane>
                <TabPane tabId={tabs.FRIENDSHIP}>
                  <ListGroup>
                    <ListGroupItem key="friendship-1">
                      <Row>
                        <Col>
                          <Select
                            value={newFriendship?.friend_1}
                            onChange={(selection) => onChange("friend_1", selection)}
                            options={creatures}
                            placeholder="Pick the first friend"
                          />
                        </Col>
                        <Col>
                          <Select
                            value={newFriendship?.friend_2}
                            onChange={(selection) => onChange("friend_2", selection)}
                            options={creatures}
                            placeholder="Pick the second friend"
                          />
                        </Col>
                        <Col>
                          <Button
                            onClick={() => saveNew()}
                            disabled={saving}
                            children="Save"
                          />
                        </Col>
                      </Row>
                    </ListGroupItem>
                    {_.map(friendships, (c, index) => {
                      return (
                        <ListGroupItem key={`friendship${index}`}>
                          <Row>
                            <Col>{c.friend_1?.label}</Col>
                            <Col>
                              <i>{c.friend_2?.label}</i>
                            </Col>
                          </Row>
                        </ListGroupItem>
                      );
                    })}
                  </ListGroup>
                </TabPane>
              </TabContent>
            </Col>
          </Row>
        </OffcanvasBody>
      </Offcanvas>
    </div>
  );
}
