from fastapi import APIRouter
from sqlalchemy import select

from ..dependencies import CurrentUser, Database
from ..models import UserSync, utc_now
from ..schemas import SyncRead, SyncWrite


router = APIRouter(prefix="/v1/sync", tags=["synchronization"])


@router.get("", response_model=SyncRead)
def read_sync(user: CurrentUser, db: Database) -> SyncRead:
    record = db.scalar(select(UserSync).where(UserSync.user_id == user.id))
    if record is None:
        return SyncRead(data=None, revision=0, updated_at=None)
    return SyncRead(
        data=record.payload,
        revision=record.revision,
        updated_at=record.updated_at,
    )


@router.put("", response_model=SyncRead)
def write_sync(request: SyncWrite, user: CurrentUser, db: Database) -> SyncRead:
    record = db.scalar(select(UserSync).where(UserSync.user_id == user.id))
    if record is None:
        record = UserSync(user_id=user.id, payload=request.data, revision=1)
        db.add(record)
    else:
        record.payload = request.data
        record.revision += 1
        record.updated_at = utc_now()
    db.commit()
    db.refresh(record)
    return SyncRead(
        data=record.payload,
        revision=record.revision,
        updated_at=record.updated_at,
    )
