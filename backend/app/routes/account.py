from fastapi import APIRouter, Response, status

from ..dependencies import CurrentUser, Database


router = APIRouter(prefix="/v1/account", tags=["account"])


@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
def delete_account(user: CurrentUser, db: Database) -> Response:
    # The relationship cascade removes the backup in the same transaction.
    # Subsequent uses of any issued token fail the current-user lookup.
    db.delete(user)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
