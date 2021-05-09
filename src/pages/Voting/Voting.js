import { ListGroup, Badge, Container } from "react-bootstrap";
import Tiers from "../../components/voting/tiers";

const Voting = () => {
  return (
    <Container>
      <h2>
        Proposals <Badge variant="info">5</Badge>
      </h2>
      <ListGroup>
        <ListGroup.Item>
          <div>
            <Badge variant="light">All</Badge>{" "}
            <Badge variant="light">Pending</Badge>{" "}
            <Badge variant="light">Active</Badge>{" "}
            <Badge variant="light">Closed</Badge>{" "}
          </div>
        </ListGroup.Item>
        <ListGroup.Item>
          {" "}
          <Badge pill variant="success">
            Active{" "}
          </Badge>{" "}
          Cras justo odio
        </ListGroup.Item>
        <ListGroup.Item>
          <Badge pill variant="secondary">
            Pending{" "}
          </Badge>{" "}
          Dapibus ac facilisis in
        </ListGroup.Item>
        <ListGroup.Item>
          <Badge pill variant="dark">
            Closed{" "}
          </Badge>{" "}
          Morbi leo risus
        </ListGroup.Item>
        <ListGroup.Item>
          <Badge pill variant="success">
            Active{" "}
          </Badge>{" "}
          Porta ac consectetur ac
        </ListGroup.Item>
        <ListGroup.Item>
          <Badge pill variant="success">
            Active{" "}
          </Badge>{" "}
          Vestibulum at eros
        </ListGroup.Item>
      </ListGroup>

      <Tiers/>
    </Container>
  );
};

export default Voting;
