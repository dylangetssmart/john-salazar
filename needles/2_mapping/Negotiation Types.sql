select distinct
	kind
from [Needles]..negotiation n
where
	ISNULL(kind, '') <> ''
order by n.kind