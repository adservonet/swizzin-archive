<?php

namespace SystemCtl\Unit;

/**
 * Class Service
 *
 * @package SystemCtl\Unit
 */
class Service extends AbstractUnit
{
    /**
     * @var string
     */
    const UNIT = 'service';

    /**
     * @inheritdoc
     */
    protected function getUnitSuffix(): string
    {
        return static::UNIT;
    }
}
